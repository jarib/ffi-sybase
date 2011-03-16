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
      finish
    end

    def finish
      to_ptr.free
      @ptr = nil
    end

    def to_ptr
      @ptr or raise "command #{self} already ran or was not initialized"
    end

    private
    
    def set_command
      Lib.check Lib.ct_command(to_ptr, CS_LANG_CMD, @str.to_s, CS_NULLTERM, CS_UNUSED)
    end

    def send
      Lib.check Lib.ct_send(to_ptr), "ct_send failed"
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
          state = :ok
        when CS_CMD_FAIL
          state = :failed
        when CS_ROW_RESULT, CS_CURSOR_RESULT, CS_PARAM_RESULT, CS_STATUS_RESULT, CS_COMPUTE_RESULT
          fetch_data
        else
          state = :failed
        end

        if state == :failed
          cancel
          raise Error, "error examining result of #{self.inspect} (state = #{state})"
        end
      end
    end

    def successful?(intptr)
      @return_code = Lib.ct_results(to_ptr, intptr)
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
        df[:maxlength] = Lib.display_length(df) + 1

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

        p [row_count, Hash[data_formats.zip(column_datas).map { |df, cd| [df.name, cd.value] }]]
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


  end # Command
end # Sybase
