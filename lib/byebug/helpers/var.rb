require 'byebug/helpers/eval'

module Byebug
  module Helpers
    #
    # Utilities for variable subcommands
    #
    module VarHelper
      include EvalHelper

      def var_list(ary, binding = default_binding)
        vars = ary.sort.map do |name|
          [name, safe_inspect(silent_eval(name.to_s, binding))]
        end

        puts prv(vars, 'instance')
      end

      def var_global
        globals = global_variables.reject do |v|
          [:$IGNORECASE, :$=, :$KCODE, :$-K, :$binding].include?(v)
        end

        var_list(globals)
      end

      def var_instance(str)
        obj = single_thread_eval(str || 'self')

        var_list(obj.instance_variables, obj.instance_eval { binding })
      end

      def var_local
        locals = @state.context.frame_locals
        cur_self = @state.context.frame_self(@state.frame)
        locals[:self] = cur_self unless cur_self.to_s == 'main'
        puts prv(locals.keys.sort.map { |k| [k, locals[k]] }, 'instance')
      end

      def safe_inspect(var)
        var.inspect
      rescue
        safe_to_s(var)
      end

      def safe_to_s(var)
        var.to_s
      rescue
        '*Error in evaluation*'
      end
    end
  end
end
