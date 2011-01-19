#
# Instanciates the _wlang_ template using key/value pairs given by _hash_. 
# _buffer_ is expected to be an IO object. Raises a RuntimeError if a 
# reference to an unexisting variable is found.
#
# Following markups are recognized:
# - ${varname} are replaced by the entities-encoding of hash[varname] 
# - +{varname} are replaced by hash[varname] without encoding
# - @{varname} are replaced by the result returned by the _varname_ singleton 
#              method.
#
def instantiate(hash, buffer)
  File.open(@template, "r") do |f|
    f.each_line do |line|
      # matches ${...}, +{...} and @{...}
      while matchdata = /([$+@])\{([^\}]+)\}/.match(line)
        tagtype, varname = matchdata[1], matchdata[2]
        buffer << matchdata.pre_match
        case tagtype
        when '$' # reference to a variable (encoding required)
          raise "No data found for #{varname}" unless hash.has_key?(varname)
          buffer << @encoder.encode(hash[varname])
        when '@' # reference to an action, we use singleton methods here
          raise "Action #{varname} not found" unless self.respond_to?(varname)
          buffer << self.send(varname)
        when '+' # Template inclusion (no encoding)
          raise "No data found for #{varname}" unless hash.has_key?(varname)
          buffer << hash[varname]
        end
        line = matchdata.post_match
      end
      buffer << line
    end
  end
end  
