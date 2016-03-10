module TTML
  class Document
    attr_reader :doc
    attr_reader :namespaces
    attr_writer :lines

    def initialize(file_or_stream)
      stream      = file_or_stream.is_a?(IO) ? file_or_stream : File.open(file_or_stream)
      @doc        = Nokogiri::XML(stream)
      @namespaces = @doc.collect_namespaces

      @subs_ns = if @namespaces.invert["http://www.w3.org/2006/10/ttaf1"]
        @namespaces.invert["http://www.w3.org/2006/10/ttaf1"].sub(/^xmlns:/, '')
      elsif @namespaces.invert["http://www.w3.org/2006/10/ttaf1"]
        @namespaces.invert["http://www.w3.org/2006/10/ttaf1"].sub(/^xmlns:/, '')
      end

      @meta_ns = if @namespaces.invert["http://www.w3.org/2006/10/ttaf1#metadata"]
        @namespaces.invert["http://www.w3.org/2006/10/ttaf1#metadata"].sub(/^xmlns:/,'')
      elsif @namespaces.invert["http://www.w3.org/ns/ttml#metadata"]
        @namespaces.invert["http://www.w3.org/ns/ttml#metadata"].sub(/^xmlns:/,'')
      end
    end

    def self.parse(file_or_stream)
      document = new(file_or_stream)
      document.parse_document
      document
    end

    def subtitle_stream(from = 0.0, to = nil)
      to = to || 99999999999.99
      @all_subs ||= doc.xpath("/#{ @subs_ns }:tt/#{ @subs_ns }:body/#{ @subs_ns }:div/#{ @subs_ns }:p")
      @all_subs.select {|n|
        # puts "Vedo se #{ n['begin'].to_f } >= #{ from } e se #{ n['end'].to_f } <= #{ to }"
        (n['begin'].to_f >= from) && (n['end'].to_f <= to)
      }
    end

    def parse_document
      subtitle_stream.each_with_index do |node, index|
        line = Line.new

        begin
          line.sequence = index + 1

          if (line.start_time = Util.timecode(Util.smpte_time(node.attributes['begin'].value))) == nil
            line.error = "#{index}, Invalid formatting of start timecode, [#{node.attributes['begin'].value}]"
            $stderr.puts line.error if @debug
          end

          if (line.end_time = Util.timecode(Util.smpte_time(node.attributes['end'].value))) == nil
            line.error = "#{index}, Invalid formatting of end timecode, [#{node.attributes['end'].value}]"
            $stderr.puts line.error if @debug
          end

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
      doc.xpath("//#{ @meta_ns }:title")[0].children[0].content
    end

    def description
      doc.xpath("//#{ @meta_ns }:description")[0].children[0].content
    end

    def copyright
      doc.xpath("//#{ @meta_ns }:copyright")[0].children[0].content
    end

  end
end
