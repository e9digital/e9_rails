module E9Rails::ActiveRecord
  module Scopes
    module Times
      extend ActiveSupport::Concern

      included do
        scope :from_time,  lambda {|*args| args.flatten!; for_time_range(args.shift, nil, args.extract_options!) }
        scope :until_time, lambda {|*args| args.flatten!; for_time_range(nil, args.shift, args.extract_options!) }

        scope :for_time_range, lambda {|*args|
          opts = args.extract_options!

          args.flatten!

          # try to determine a datetime from each arg, skipping #to_time on passed strings because
          # it doesn't handle everything DateTime.parse can, e.g. 'yyyy/mm'
          args.map! do |t| 
            t.presence and 

              # handle string years 2010, etc.
              t.is_a?(String) && /^\d{4}$/.match(t) && Date.civil(t.to_i) ||

              # handle Time etc. (String#to_time doesn't handle yyyy/mm properly)
              !t.is_a?(String) && t.respond_to?(:to_time) && t.to_time || 

              # try to parse it
              DateTime.parse(t) rescue nil
          end

          time_column = opts[:column] || :created_at

          if !args.any?
            where('1=0')
          elsif args.all?
            where(time_column => args[0]..args[1])
          elsif args[0]
            where(arel_table[time_column].gteq(args[0]))
          else
            where(arel_table[time_column].lteq(args[1]))
          end
        }
      end
    end
  end
end
