# Borrowed from customink's foodcritic rules
# See https://github.com/customink-webops/foodcritic-rules/blob/master/rules.rb

rule 'RALY001', 'Prefer single-quoted strings' do
  tags %w{style strings}
  recipe do |ast, filename|
    
    next if filename.end_with? '.erb'

    lines = File.readlines(filename)

    lines.collect.with_index do |line, index|
      # Don't flag if there is a #{} or ' in the line
      if line.match('"(.*)"') && !line.match('^\s+<.+?[class|plugin]="(.+?)".*?>\s*$') && !line.match('\A\s?#') && !line.match('\'(.*)"(.*)"(.*)\'') && !line.match('"(.*)(#{.+}|\'|\\\a|\\\b|\\\r|\\\n|\\\s|\\\t)(.*)"')
        {
          :filename => filename,
          :matched => recipe,
          :line => index + 1,
          :column => 0
        }
      end
    end.compact.flatten
  end
end
