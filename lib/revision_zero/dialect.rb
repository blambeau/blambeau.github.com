WLang::dialect('revtpl', '.wtpl') do
  ruby_require "cgi", "wlang/dialects/xhtml_dialect" do
    encoders WLang::EncoderSet::XHtml
    rules WLang::RuleSet::Basic
    rules WLang::RuleSet::Encoding
    rules WLang::RuleSet::Imperative
    rules WLang::RuleSet::Buffering
    rules WLang::RuleSet::Context
    rules WLang::RuleSet::XHtml

    rule "<<!" do |parser, offset|
      file, reached = parser.parse(offset, "wlang/uri")
      if File.file?(file) and File.readable?(file)
        ctx = parser.state.scope.dup.to_h
        get = RevisionZero::Templates.go(file, ctx, true)
        [get, reached]
      else
        parser.error(offset, "unable to apply cache rule <<!{#{file}}, not a file or not readable (#{file})")
      end
    end
    
  end
end

WLang::dialect('revzero', '.r0') do 
  ruby_require "cgi", "wlang/dialects/xhtml_dialect" do
    encoders WLang::EncoderSet::XHtml
    rules WLang::RuleSet::Basic
    rules WLang::RuleSet::Encoding
    rules WLang::RuleSet::Imperative
    rules WLang::RuleSet::Buffering
    rules WLang::RuleSet::Context
    rules WLang::RuleSet::XHtml
    post_transform "redcloth/xhtml"
    
    rule "#<" do |parser, offset|
      uri, lexer = nil
      uri, reached = parser.parse(offset, "wlang/uri")
      if parser.has_block?(reached)
        lexer = uri.to_sym
        text, reached = parser.parse_block(reached)
        highlighted = Albino.colorize(text, lexer)
        ["<notextile>#{highlighted}</notextile>", reached]
      else
        file = parser.template.file_resolve(uri, false)
        if File.file?(file) and File.readable?(file)
          lexer = File.extname(file)[1..-1].to_sym
          lexer = :text if lexer == :r0
          highlighted = Albino.colorize(File.read(file), lexer)
          ["<notextile>#{highlighted}</notextile>", reached]
        else
          text = parser.parse(offset, "wlang/dummy")[0]
          parser.error(offset, "unable to apply highligh rule #<{#{text}}, not a file or not readable (#{file})")
        end
      end
    end
    
    rule "!!" do |parser,offset| 
      text, reached = parser.parse(offset)
      ["<p class=\"attention\">#{text}</p>", reached]
    end
    
    rule "@?" do |parser,offset| 
      require 'uri'
      link, reached = parser.parse(offset)
      if parser.has_block?(reached)
        term, reached = parser.parse_block(reached)
      else
        term = link
      end
      link = <<-LINK.strip
        <a href="http://www.google.com/search?q=#{URI.escape(link)}" target="_blank">#{term}</a>
      LINK
      [ link, reached ]
    end
    
  end
end

# We reopen the String class to tune some WLang 
# extension points
class String
  
  # Renders a link tag <a href="url">label</a> for the 
  # static version of the website
  def to_xhtml_link(url, label)
    if url =~ /^(http|ftp)/
      "<a target=\"_blank\" href=\"#{url}\">#{label}</a>"
    else
      "<a href=\"#{url}\">#{label}</a>"
    end
  end
  
end
