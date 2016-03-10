module TTML
  class Util
    class << self

      # takes a string offset (as found in ttml nodes) and returns smpte string;
      # Used in converting to SubRip.
      #
      # Ex: 0.0s => 00:00:00.0
      # Ex: 63.5s => 00:01:03.500
      def smpte_time(offset)
        hours = minutes = seconds = millisecs = 0
        f_off = offset.to_s.sub(/s$/, '').to_f
        millisecs = ((f_off - f_off.to_i) * 1000).to_i
        minutes, seconds = f_off.divmod(60)
        hours, minutes = minutes.divmod(60)
        "#{ sprintf('%02d', hours) }:#{ sprintf('%02d', minutes) }:#{ sprintf('%02d', seconds) },#{ millisecs }"
      end

      def framerate(framerate_string)
        mres = framerate_string.match(/(?<fps>\d+((\.)?\d+))(fps)/)
        mres ? mres["fps"].to_f : nil
      end

      def id(id_string)
        mres = id_string.match(/#(?<id>\d+)/)
          mres ? mres["id"].to_i : nil
      end

      def timecode(timecode_string)
        mres = timecode_string.match(/(?<h>\d+):(?<m>\d+):(?<s>\d+)[,.](?<ms>\d+)/)
        mres ? "#{mres["h"].to_i * 3600 + mres["m"].to_i * 60 + mres["s"].to_i}.#{mres["ms"]}".to_f : nil
      end

      def timespan(timespan_string)
        factors = {
          "ms" => 0.001,
          "s" => 1,
          "m" => 60,
          "h" => 3600
        }
        mres = timespan_string.match(/(?<amount>(\+|-)?\d+((\.)?\d+)?)(?<unit>ms|s|m|h)/)
        mres ? mres["amount"].to_f * factors[mres["unit"]] : nil
      end

      def strip_tags(text)
        text.sub(/.+00">([^<]*)<.+/, '\1')
      end
    end
  end
end
