module Middleman
  module GoogleAnalytics
    class Options < Struct.new(:tracking_id, :anonymize_ip, :allow_linker, :domain_name, :debug); end

    class << self
      def options
        @@options ||= Options.new
      end

      def registered(app, options={})
        @@options ||= Options.new(*options.values_at(*Options.members))
        yield @@options if block_given?

        if @@options.allow_linker and not @@options.domain_name
          $stderr.puts 'Google Analytics: Please specify a domain_name when using allow_linker'
          raise 'No domain_name given'
        end

        app.send :include, InstanceMethods
      end
      alias :included :registered
    end

    module InstanceMethods
      def google_analytics_tag
        options = ::Middleman::GoogleAnalytics.options

        options.debug = development? if options.debug.nil?
        ga = options.debug ? 'u/ga_debug' : 'ga'
        domain_name = options.domain_name

        if tracking_id = options.tracking_id
          gaq = []
          gaq << ['_setAccount', "#{tracking_id}"]
          gaq << ['_setDomainName', "#{domain_name}"] if domain_name
          gaq << ['_setAllowLinker', true] if options.allow_linker
          gaq << ['_gat._anonymizeIp'] if options.anonymize_ip
          gaq << ['_trackPageview']
          %Q{<script>
  var _gaq = [#{gaq.map(&:to_s).join(', ')}];
  (function(d) {
    var g = d.createElement('script'),
        s = d.scripts[0];
    g.src = '//www.google-analytics.com/#{ga}.js';
    s.parentNode.insertBefore(g, s);
  }(document));
</script>}
        end
      end
    end
  end
end
