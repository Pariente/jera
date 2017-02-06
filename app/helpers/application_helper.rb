module ApplicationHelper
  def title(text)
    content_for :title, "Jera - #{text}"
  end
end
