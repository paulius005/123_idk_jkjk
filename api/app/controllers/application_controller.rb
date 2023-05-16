class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  # https://stackoverflow.com/a/48172520/1933131
  def fallback_index_html
    respond_to do |format|
      format.html { render body: Rails.root.join('public/index.html').read }
    end
  end
end