# frozen_string_literal: true

module Jekyll
  class SeoTag
    # A drop representing the page image
    # The image path will be pulled from:
    #
    # 1. The `image` key if it's a string
    # 2. The `image.path` key if it's a hash
    # 3. The `image.facebook` key
    # 4. The `image.twitter` key
    class ImageDrop < Jekyll::Drops::Drop
      include Jekyll::SeoTag::UrlHelper

      # Initialize a new ImageDrop
      #
      # page - The page hash (e.g., Page#to_liquid)
      # context - the Liquid::Context
      def initialize(page: nil, context: nil)
        raise ArgumentError unless page && context

        @mutations = {}
        @page = page
        @context = context
      end

      # Called path for backwards compatability, this is really
      # the escaped, absolute URL representing the page's image
      # Returns nil if no image path can be determined
      def path
        @path ||= filters.uri_escape(absolute_url) if absolute_url
      end
      alias_method :to_s, :path

      private

      attr_accessor :page, :context

      # The normalized image hash with a `path` key (which may be nil)
      def image_hash
        @image_hash ||= begin
          image_meta = page["image"]

          case image_meta
          when Hash
            { "path" => nil }.merge!(image_meta)
          when String
            { "path" => image_meta }
          else
            { "path" => nil }
          end
        end
      end
      alias_method :fallback_data, :image_hash

      def raw_path
        @raw_path ||= begin
          image_hash["twitter"] || image_hash["facebook"] || image_hash["path"]
        end
      end

      def absolute_url
        return unless raw_path

        @absolute_url ||= build_absolute_path
      end

      def build_absolute_path
        return raw_path unless raw_path.is_a?(String) && absolute_url?(raw_path) == false
        return filters.absolute_url(raw_path) if raw_path.start_with?("/")

        page_dir = @page["url"]
        page_dir = File.dirname(page_dir) unless page_dir.end_with?("/")

        filters.absolute_url File.join(page_dir, raw_path)
      end

      def filters
        @filters ||= Jekyll::SeoTag::Filters.new(context)
      end
    end
  end
end
