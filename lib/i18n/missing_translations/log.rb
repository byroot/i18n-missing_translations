require 'yaml'

module I18n
  class MissingTranslations
    class Log < Hash
      def log(keys)
        keys = keys.dup
        key = keys.pop.to_s
        log = keys.inject(self) do |log, k|
          sublog = if log.key?(k.to_s)
            log[k.to_s]
          else
            log[k.to_s] = {}
          end
          if sublog.is_a?(String)
            string_key = (keys.take_while { |key| key != k } + [k]).join('.')
            raise "Invalid key hierarchy: can't define #{keys.join('.')}.#{key} because #{string_key} is already defined."
          end
          sublog
        end
        log[key] = key.to_s.gsub('_', ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
      end

      def dump(out = $stdout)
        out.puts(to_yml) unless empty?
      end

      def read(filename)
        self.replace(YAML.load_file(filename)) rescue nil
      end

      def write(filename)
        File.open(filename, 'w+') { |f| f.write(to_yml) } unless empty?
      end

      def to_yml
        YAML.dump(Hash[*to_a.flatten]).split("\n").map(&:rstrip).join("\n")
      end
    end
  end
end
