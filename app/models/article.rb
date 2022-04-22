class Article < ApplicationRecord
    has_paper_trail
                has_rich_text :body

end
