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
        Lib.check Lib.ct_describe(to_ptr, i + 1, data_formats[i])
        p :name => data_formats[i].name
      end
    ensure
      # ?
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

    class ColumnData < FFI::Struct
      layout :indicator, :int,
             :value,     :pointer,
             :valuelen,  :int
    end

    class DataFormat < FFI::Struct
      layout :name,       [:char, CS_MAX_CHAR],
             :namelen,    :int,
             :datatype,   :int,
             :format,     :int,
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
