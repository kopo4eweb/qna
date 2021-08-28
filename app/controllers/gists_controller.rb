# frozen_string_literal: true

class GistsController < ApplicationController
  skip_authorization_check

  def load
    gist_url = params[:url]
    link_id  = params[:id].to_i

    file = "<script>call_link_#{link_id}();"
    file += "function call_link_#{link_id}() {"

    # rubocop:disable Security/Open
    if gist_url && link_id
      URI.open(gist_url) do |f|
        f.each_line { |line| file += line }
      end
    end
    # rubocop:enable Security/Open

    file += '} </script>'

    file = file.gsub('document.write', "$('.link-#{link_id}').append")

    render plain: file
  end
end
