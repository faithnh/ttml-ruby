module TTML
  class Document
    attr_reader :doc
    attr_reader :namespaces
    attr_reader :namespace_type
    attr_writer :lines

    NAMESPACES = {
      :ttaf1 => "http://www.w3.org/2006/10/ttaf1",
      :ttml1 => "http://www.w3.org/ns/ttml"
    }

    def initialize(file_or_stream)
      stream      = file_or_stream.is_a?(IO) ? file_or_stream : File.open(file_or_stream)
      @doc        = Nokogiri::XML(stream)
      @namespaces = @doc.collect_namespaces
    end

    def self.parse(file_or_stream)
      document = new(file_or_stream)
      document.parse_document
      document
    end

    def subtitle_stream(from = 0.0, to = nil)
      to = to || 99999999999.99
      @all_subs ||= doc.xpath("/#{ subs_ns }:tt/#{ subs_ns }:body/#{ subs_ns }:div/#{ subs_ns }:p")
      @all_subs.select {|n|
        (n['begin'].to_f >= from) && (n['end'].to_f <= to)
      }
    end

    def parse_document
      subtitle_stream.each_with_index do |node, index|
        line = Line.new

        begin
          line.sequence   = index + 1
          line.start_time = parse_time_from_node(node, 'begin', line)
          line.end_time   = parse_time_from_node(node, 'end', line)

          if node.attributes['style'] && node.attributes['style'].value
            line.style = node.attributes['style'].value
          end

          node.children.each do |child|
            line.text << child.text
          end

          lines << line
        rescue Exception => ex
          line.error = "##{index}, general error, [#{ex.message}]"
          $stderr.puts line.error if @debug
          raise ex
        end
      end
      self
    end

    def lines
      @lines ||= []
    end

    def errors
      lines.map { |l| l.error if l.error }.compact
    end

    def title
      doc.xpath("//#{ meta_ns }:title")[0].children[0].content
    end

    def description
      doc.xpath("//#{ meta_ns }:description")[0].children[0].content
    end

    def copyright
      doc.xpath("//#{ meta_ns }:copyright")[0].children[0].content
    end

    private

    def subs_ns
      NAMESPACES.each do |type, ns|
        if ns = ns_lookup(ns)
          @namespace_type = type
          return ns
        end
      end
      raise InvalidNamespace
    end

    def meta_ns
      NAMESPACES.each do |type, ns|
        if ns = ns_lookup("#{ns}#metadata")
          return ns
        end
      end
      raise InvalidNamespace
    end

    def ns_lookup(name)
      if @namespaces.invert[name]
        return @namespaces.invert[name].sub(/^xmlns:/, '')
      end
    end

    def parse_time_from_node(node, attribute, line)
      if namespace_type == :ttaf1
        if node.attributes[attribute] && (time = node.attributes[attribute].value.to_f)
          return time
        else
          line.error = "#{line.sequence}, Invalid formatting of start timecode, [#{node.attributes[attribute].inspect}]"
          $stderr.puts line.error if @debug
        end
      elsif namespace_type == :ttml1
        if node.attributes[attribute] && (time = Util.timecode(node.attributes[attribute].value))
          return time
        else
          line.error = "#{line.sequence}, Invalid formatting of start timecode, [#{node.attributes[attribute].inspect}]"
          $stderr.puts line.error if @debug
        end
      else
        raise UnknownNamespaceType
      end
    end
  end
end
