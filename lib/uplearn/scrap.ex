defmodule Uplearn.Scrap do
  @moduledoc """
  Scrap Module
  """

  @doc """
  Fetches the url to scrap information about images and anchor tags.
  Returns object of assets & links.

  ## Examples

      iex> Uplearn.Scrap.fetch("https://www.amazon.in/")
      %{
        assets: [],
        links: []
      }
  """
  def fetch(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, html} = Floki.parse_document(body)

        links =
          html
          |> Floki.find("a")
          |> Floki.attribute("href")

        assets =
          html
          |> Floki.find("img")
          |> Floki.attribute("src")

        {:ok, %{assets: assets, links: links}}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Response{status_code: _, body: _body}} ->
        {:error, :unexpected_status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
