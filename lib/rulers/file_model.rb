# frozen_string_literal: true

require "multi_json"

module Rulers
  module Model
    class FileModel
      attr_reader :filename, :id, :data

      def initialize(filename)
        @filename = filename
        extract_id
        load_file
      end

      def [](key)
        data[key.to_s]
      end

      def []=(key, value)
        data[key.to_s] = value
      end

      def self.find(id)
        FileModel.new("db/quotes/#{id}.json")
      rescue StandardError
        nil
      end

      def self.all
        files = Dir["db/quotes/*.json"]
        files.map { |f| FileModel.new(f) }
      end

      def self.create(attrs)
        hash = {
          "submitter" => attrs["submitter"] || "",
          "quote" => attrs["quote"] || "",
          "attribution" => attrs["attribution"] || ""
        }
        files = Dir["db/quotes/*.json"]
        names = files.map { |f| File.split(f)[-1] }
        highest = names.map(&:to_i).max
        id = highest + 1
        File.open("db/quotes/#{id}.json", "w") do |f|
          f.write <<~TEMPLATE
            {
            "submitter": "#{hash["submitter"]}",
            "quote": "#{hash["quote"]}",
            "attribution": "#{hash["attribution"]}"
            }
          TEMPLATE
        end
        FileModel.new("db/quotes/#{id}.json")
      end

      def update(attrs)
        data["submitter"] = attrs["submitter"] || data["submitter"]
        data["quote"] = attrs["quote"] || data["quote"]
        data["attribution"] = attrs["attribution"] || data["attribution"]
        File.write(filename, MultiJson.dump(data))
      end

      def self.find_all_by_submitter(submitter)
        files = Dir["db/quotes/*.json"]
        files = files.map { |f| FileModel.new(f) }
        files.select { |f| f["submitter"] == submitter }
      end

      # data.keys.each do |key|
      #   define_method(key) { data[key] }
      #   define_method("#{key}=") { |value| data[key] = value }
      # end

      private

      def extract_id
        basename = File.basename(filename)[-1]
        @id = File.basename(basename, ".json").to_i
      end

      def load_file
        obj = File.read(filename)
        @data = MultiJson.load(obj)
      end
    end
  end
end
