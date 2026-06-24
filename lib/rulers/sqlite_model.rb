require "sqlite3"
require "rulers/util"

DB = SQLite3::Database.new "test.db"

module Rulers
  module Model
    class SQLiteModel
      def initialize(data = nil)
        @hash = data
      end

      def self.to_sql(val)
        case val
        when NilClass
          "null"
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't convert #{val.class} to SQL"
        end
      end

      def self.create(values)
        values.delete("id")
        keys = schema.keys - ["id"]
        vals = keys.map do |key|
          values[key] ? to_sql(values[key]) : "null"
        end
        DB.execute "INSERT INTO #{table} (#{keys.join(", ")}) VALUES (#{vals.join(", ")})"
        raw_vals = keys.map { |k| values[k] }
        data = Hash[keys.zip(raw_vals)]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        new(data)
      end

      def self.count
        DB.execute(<<~SQL)[0][0]
          SELECT COUNT(*) FROM #{table}
        SQL
      end

      def self.find(id)
        row = DB.execute <<~SQL
          select #{schema.keys.join ","} from #{table}
          where id = #{id};
        SQL
        data = Hash[schema.keys.zip(row[0])]
        new(data)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        fields = @hash.map { |k, v| "#{k} = #{self.class.to_sql(v)}" }.join(", ")
        DB.execute "UPDATE #{self.class.table} SET #{fields} WHERE id = #{@hash["id"]}"
        true
      end

      def save
        save!
      rescue StandardError
        false
      end

      def self.all
        rows = DB.execute <<~SQL
          select #{schema.keys.join ","} from #{table}
        SQL
        rows.map do |row|
          data = Hash[schema.keys.zip(row)]
          new(data)
        end
      end

      def self.table
        Rulers.to_underscore name
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end

        # @schema.each_key do |name|
        #   define_method(name) do
        #     self[name]
        #   end

        #   define_method("#{name}=") do |value|
        #     self[name] = value
        #   end
        # end

        @schema
      end

      def method_missing(name, *args)
        if @hash[name.to_s]
          self.class.class_eval do
            define_method(name) do
              @hash[name.to_s]
            end
          end
          return send name
        end
        if name.to_s[-1..] == "="
          col_name = name.to_s[0..-2]
          self.class.class_eval do
            define_method(name) do |value|
              self[col_name] = value
            end
          end
          send(name, args[0])

        end
        super
      end
    end
  end
end
