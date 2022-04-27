# Inspired by this Stack Overflow answer
# https://stackoverflow.com/a/70014060
Rails.application.config.to_prepare do
  ActionText::RichText.include HasPaperTrail
end
