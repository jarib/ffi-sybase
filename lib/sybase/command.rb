module Sybase
  class Command

    def initialize(connection, str)
      FFI::MemoryPointer.new(:pointer) do |ptr|
        Lib.check Lib.ct_cmd_alloc(connection, ptr), "ct_cmd_alloc"
        @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:ct_cmd_drop))
      end

      @str = str.to_s
    end

    def execute
      set_command
      send
      results
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
      Lib.check Lib.ct_command(to_ptr, CS_LANG_CMD, @str, @str.bytesize, CS_UNUSED)
    end

    def send
      Lib.check Lib.ct_send(to_ptr), "ct_send failed"
    end

    def cancel
      Lib.ct_cancel(nil, to_ptr, CS_CANCEL_CURRENT)
    end

    COMMAND_RESULTS = {
      CS_CMD_SUCCEED    => :succeed,
      CS_CMD_DONE       => :done,
      CS_CMD_FAIL       => :fail,
      CS_ROW_RESULT     => :row,
      CS_CURSOR_RESULT  => :cursor,
      CS_PARAM_RESULT   => :param,
      CS_COMPUTE_RESULT => :compute,
      CS_STATUS_RESULT  => :status
    }

    def results
      intptr = FFI::MemoryPointer.new(:int)

      state = :initial

      returned = []

      while successful? intptr
        restype = intptr.read_int
        restype = COMMAND_RESULTS[restype] || restype

        case restype
        when :succeed, # no row - e.g. insert/update
             :done     # results completely processed
          returned << Result.new(restype, nil, result_info(CS_ROW_COUNT), result_info(CS_TRANS_STATE))
        when :fail
          returned << Result.new(restype, nil, result_info(CS_ROW_COUNT), result_info(CS_TRANS_STATE))
        when :row,
             :cursor,
             :param,
             :compute,
             :status

          columns, rows = fetch_data
          returned << Result.new(restype, :columns => columns, :rows => rows)
        else
          returned << Result.new(restype, nil, result_info(CS_ROW_COUNT), result_info(CS_TRANS_STATE))
        end

        # check context timeout?
      end

      returned
    end

    class Result
      attr_reader :type

      def initialize(type, data, row_count = nil, transaction_state = nil)
        @type              = type
        @data              = data
        @row_count         = row_count
        @transaction_state = transaction_state
      end

      def as_json(options = nil)
        case @type
        when :row
          cols, rows = @data[:columns], @data[:rows]
          rows.map do |row|
            Hash[cols.zip(row)]
          end
        else
          raise NotImplementedError, "Result#as_json for #{type}"
        end
      end
    end # Result

    def successful?(intptr)
      @return_code = Lib.ct_results(to_ptr, intptr)
      @return_code == CS_SUCCEED
    end

    def fetch_data
      num_cols = fetch_column_count

      column_datas = Array.new(num_cols) { ColumnData.new }

      num_cols.times do |i|
        cd = column_datas[i]
        df = cd.format

        Lib.check Lib.ct_describe(to_ptr, i + 1, df)
        type = df[:datatype]

        case type
        when CS_TINYINT_TYPE,
             CS_SMALLINT_TYPE,
             CS_INT_TYPE,
             CS_BIT_TYPE,
             CS_DECIMAL_TYPE,
             CS_NUMERIC_TYPE
          df[:maxlength] = FFI.type_size(:int)
          df[:datatype]  = CS_INT_TYPE
          df[:format]    = CS_FMT_UNUSED

          cd.int_pointer!
        when CS_REAL_TYPE, CS_FLOAT_TYPE
          # not sure about this
          df[:maxlength] = FFI.type_size(:double)
          df[:datatype]  = CS_FLOAT_TYPE
          df[:format]    = CS_FMT_UNUSED

          cd.double_pointer!
        else # treat as String
          df[:maxlength] = Lib.display_length(df) + 1

          if type == CS_IMAGE_TYPE
            df[:format] = CS_FMT_UNUSED
          else
            df[:format] = CS_FMT_NULLTERM
            df[:datatype] = CS_CHAR_TYPE
          end

          cd.char_pointer!(df[:maxlength])
        end

        bind i, df, cd
      end

      rows_read_ptr = FFI::MemoryPointer.new(:int)
      row_count     = 0

      columns       = column_datas.map { |cd| cd.format.name }
      values        = []

      while (code = fetch_row(rows_read_ptr)) == CS_SUCCEED || code == CS_ROW_FAIL
        # increment row count
        row_count += rows_read_ptr.read_int

        if code == CS_ROW_FAIL
          raise Error, "error on row #{row_count}"
        end

        values << column_datas.map { |e| e.value }
      end

      # done processing rows, check final return code
      case code
      when CS_END_DATA
        # all good
      when CS_FAIL
        raise Error, "ct_fetch() failed"
      else
        raise Error, "unexpected return code: #{code}"
      end

      [columns, values]
    ensure
      # ?
    end

    def fetch_row(rows_read_ptr)
      Lib.ct_fetch(to_ptr, CS_UNUSED, CS_UNUSED, CS_UNUSED, rows_read_ptr)
    end

    def bind(index, data_format, column_data)
      Lib.check Lib.ct_bind(to_ptr, index + 1, data_format, column_data.pointer, column_data.valuelen_pointer, column_data.indicator_pointer)
    end

    def fetch_column_count
      num_cols = result_info(CS_NUMDATA)

      if num_cols <= 0
        cancel
        raise Error, "bad column count (#{num_cols})"
      end

      num_cols
    end

    def result_info(operation)
      int_ptr = FFI::MemoryPointer.new(:int)
      Lib.check Lib.ct_res_info(to_ptr, operation, int_ptr, CS_UNUSED, nil), "ct_res_info failed"
      num_cols = int_ptr.read_int
    end

  end # Command
end # Sybase
