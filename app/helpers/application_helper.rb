module ApplicationHelper
  def title(text)
    content_for :title, "Jera - #{text}"
  end

  def load_more_count(content)
    @load_more_count = 0

    unless content.count < 20
      @load_more_count = content.count - 20
    end
    if @load_more_count > 20
      @load_more_count = 20
    end

    return @load_more_count
  end

end
