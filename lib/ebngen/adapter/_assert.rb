
module Core

    # perform simple assertion like c <assert.h>
    # implementation raise an exception instead go to abort
    # two ways how use assert:
    # 1) assert(condition, "message")
    # 2) assert(condition) do "message" end
    # I would prefer use 2.nd way because 1.st way always 
    # evaluate the message parameter ("like #{failed_var.some_info...}")
    # while 2.nd evaluate message only if condition fails
    def assert(condition, message=nil)
        unless (condition)
            if block_given?
                message = yield(condition)
            end
            raise message == nil ? "assertion error" : message
        end
    end

    module_function :assert

end


