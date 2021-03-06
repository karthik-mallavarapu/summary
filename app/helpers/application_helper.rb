module ApplicationHelper

  def flash_class(level)

    case level
      when 'notice' then "alert alert-info"
      when 'success' then "alert alert-success"
      when 'error' then "alert alert-danger"
      when 'alert' then "alert alert-warning"
    end
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

end
