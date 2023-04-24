defmodule Uplearn.ScrapTest do
  # use Uplearn.DataCase
  use ExUnit.Case, async: true

  alias Uplearn.Scrap
  import Mock

  describe "scrap" do
    test "empty html page" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "<html></html>"}}
        end do
        assert {:ok, %{assets: [], links: []}} ==
                 Scrap.fetch("https://www.telerik.com/support/demos")
      end
    end

    test "html page with images" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "<html>
          <body> <img src=\"http://test.com/image/test.png\">
        </html>"}}
        end do
        assert {:ok, %{assets: ["http://test.com/image/test.png"], links: []}} ==
                 Scrap.fetch("https://www.telerik.com/support/demos")
      end
    end

    test "html page with links" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "<html>
          <body>   <a href=\"https://www.schools.com\">Visit schools.com!</a> </body>
        </html>"}}
        end do
        assert {:ok, %{assets: [], links: ["https://www.schools.com"]}} ==
                 Scrap.fetch("https://www.telerik.com/support/demos")
      end
    end

    test "html page with multiple links & images" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "<html>
          <body>
          <a href=\"https://www.schools.com\">Visit schools.com!</a>
          <a href=\"https://www.schools-multi.com\">Visit schools-multi.com!</a>

          <img src=\"http://test.com/image/test.png\">
          <img src=\"http://test.com/image/test-multi.png\">

          </body>
        </html>"}}
        end do
        assert {:ok,
                %{
                  assets: [
                    "http://test.com/image/test.png",
                    "http://test.com/image/test-multi.png"
                  ],
                  links: ["https://www.schools.com", "https://www.schools-multi.com"]
                }} == Scrap.fetch("https://www.telerik.com/support/demos")
      end
    end

    test "html page with page not found" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
        end do
        assert {:error, :not_found} == Scrap.fetch("https://www.telerik.com/support/demos")
      end
    end
  end
end
