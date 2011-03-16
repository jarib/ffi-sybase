module Sybase
  class Command

    def initialize(connection, str)
      @connection = connection
      ptr = FFI::MemoryPointer.new(:pointer)
      Lib.check Lib.ct_cmd_alloc(connection, ptr), "ct_cmd_alloc"

      @str = str
      @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:ct_cmd_drop))
    end

    def execute
      set_command
      send
      examine_results
    ensure
      cleanup
    end

    def to_ptr
      @ptr or raise "command #{self} not initialized"
    end

    private

    def set_command
      Lib.check Lib.ct_command(to_ptr, CS_LANG_CMD, @str.to_s, CS_NULLTERM, CS_UNUSED)
    end

    def send
      Lib.check Lib.ct_send(to_ptr), "ct_send"
    end

    def cancel
      Lib.ct_cancel(nil, to_ptr, CS_CANCEL_CURRENT)
    end

    def examine_results
      intptr = FFI::MemoryPointer.new(:int)

      state = :initial

      while successful? intptr
        restype = intptr.read_int

        case restype
        when CS_CMD_SUCCEED, CS_CMD_DONE
          p self => :succeed_done
          state = :ok
        when CS_CMD_FAIL
          p self => :fail
          state = :failed
        when CS_ROW_RESULT, CS_CURSOR_RESULT, CS_PARAM_RESULT, CS_STATUS_RESULT, CS_COMPUTE_RESULT
          fetch_data
        else
          p self => [:in_else, restype]
          state = :failed
        end

        if state == :failed
          cancel
          raise Error, "error examining result of #{self.inspect} (state = #{state})"
        end
      end
    end

    def cleanup
      to_ptr.free
      @ptr = nil
    end

    def successful?(intptr)
      @return_code = Lib.ct_results(to_ptr, intptr)
      p self => [@return_code, CS_SUCCEED]
      @return_code == CS_SUCCEED
    end

    def fetch_data
      num_cols = fetch_column_count
      column_datas = Array.new(num_cols) { ColumnData.new }

      columns_array = FFI::MemoryPointer.new(ColumnData, num_cols)
      columns_array.write_array_of_pointer(column_datas)

      data_formats = Array.new(num_cols) { DataFormat.new }

      data_format_array = FFI::MemoryPointer.new(DataFormat, num_cols)
      data_format_array.write_array_of_pointer(data_formats)

      num_cols.times do |i|
        df = data_formats[i]
        cd = column_datas[i]

        Lib.check Lib.ct_describe(to_ptr, i + 1, df)
        p :name => df.name
        df[:maxlength] = display_length(df) + 1

        # convert things to null-terminated strings
        df[:datatype] = CS_CHAR_TYPE
        df[:format] = CS_FMT_NULLTERM

        cd[:value] = FFI::MemoryPointer.new(:char, df[:maxlength])

        # bind
        valuelen_ptr = FFI::MemoryPointer.new(:int)
        indicator_ptr = FFI::MemoryPointer.new(:int)
        Lib.check Lib.ct_bind(to_ptr, i + 1, df, cd[:value], valuelen_ptr, indicator_ptr)

        cd[:valuelen] = valuelen_ptr.read_int
        cd[:indicator] = indicator_ptr.read_int
      end

      rows_read_ptr = FFI::MemoryPointer.new(:int)
      row_count = 0

      while (code = fetch_row(rows_read_ptr)) == CS_SUCCEED || code == CS_ROW_FAIL
        # increment row count
        row_count += rows_read_ptr.read_int

        if code == CS_ROW_FAIL
          raise Error, "error on row #{row_count}"
        end

        p column_datas.map { |e| e[:value].read_string }
      end

      # done processing rows, check final return code
      case code
      when CS_END_DATA
        puts "All done processing rows."
      when CS_FAIL
        raise Error, "ct_fetch() failed"
      else
        raise Error, "unexpected return code: #{code}"
      end
    ensure
      # ?
    end

    def fetch_row(rows_read_ptr)
      Lib.ct_fetch(to_ptr, CS_UNUSED, CS_UNUSED, CS_UNUSED, rows_read_ptr)
    end

    def fetch_column_count
      num_cols_ptr = FFI::MemoryPointer.new(:int)
      Lib.check Lib.ct_res_info(to_ptr, CS_NUMDATA, num_cols_ptr, CS_UNUSED, nil)
      num_cols = num_cols_ptr.read_int

      if num_cols <= 0
        raise Error, "ct_res_info() returned zero or negative column count"
      end

      num_cols
    end

    def display_length(column)
      len = case column[:datatype]
            when CS_CHAR_TYPE, CS_LONGCHAR_TYPE, CV_VARCHAR_TYPE, CS_TEXT_TYPE, CS_IMAGE_TYPE
              [column[:maxlength], MAX_CHAR_BUF].min
            when CS_UNICHAR_TYPE
              [column[:maxlength] / 2, MAX_CHAR_BUF].min
            when CS_BINARY_TYPE, CS_VARBINARY_TYPE
              [(2 * column[:maxlength]) + 2, MAX_CHAR_BUF].min
            when CS_BIT_TYPE, CS_TINYINT_TYPE
              3
            when CS_SMALLINT_TYPE
              6
            when CS_INT_TYPE
              11
            when CS_REAL_TYPE, CS_FLOAT_TYPE
              20
            when CS_MONEY_TYPE, CS_MONEY4_TYPE
              24
            when CS_DATETIME_TYPE, CS_DATETIME4_TYPE
              30
            when CS_NUMERIC_TYPE, CS_DECIMAL_TYPE
              CS_MAX_PREC + 2
            else
              12
            end


      [column[:name].size + 1, len].max
    end

    class ColumnData < FFI::Struct
      layout :indicator, :int,
             :value,     :pointer,
             :valuelen,  :int
    end

    class DataFormat < FFI::Struct
      layout :name,       [:char, CS_MAX_CHAR],
             :namelen,    :int,
             :datatype,   :int,
             :format,    :int,
             :maxlength,  :int,
             :scale,      :int,
             :precision,  :int,
             :status,     :int,
             :count,      :int,
             :usertype,   :int,
             :locale,     :pointer

      def name
        self[:name].to_s
      end
    end

  end # Command
end # Sybase
