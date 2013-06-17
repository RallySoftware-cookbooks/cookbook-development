# Borrowed from customink's foodcritic rules
# See https://github.com/customink-webops/foodcritic-rules/blob/master/rules.rb

rule 'RALY001', 'Prefer single-quoted strings' do
  tags %w{style strings}
  cookbook do |path|
    recipes = Dir["#{path}/**/*.rb"]
    recipes.collect do |recipe|
      lines = File.readlines(recipe)

      lines.collect.with_index do |line, index|
        # Don't flag if there is a #{} or ' in the line
        if line.match('"(.*)"') && !line.match('\A\s?#') && !line.match('\'(.*)"(.*)"(.*)\'') && !line.match('"(.*)(#{.+}|\'|\\\a|\\\b|\\\r|\\\n|\\\s|\\\t)(.*)"')
          {
            :filename => recipe,
            :matched => recipe,
            :line => index + 1,
            :column => 0
          }
        end
      end.compact
    end.flatten
  end
end
