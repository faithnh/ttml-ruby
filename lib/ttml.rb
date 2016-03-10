require "nokogiri"

module TTML
  class InvalidNamespace < StandardError; end
  class UnknownNamespaceType < StandardError; end
end

require "ttml/version"
require "ttml/util"
require "ttml/line"
require "ttml/document"
