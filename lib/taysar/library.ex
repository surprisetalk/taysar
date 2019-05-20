defmodule Taysar.Library do

  require Earmark

  require File

  # TODO: Each of these should return richer data
  # TODO:   Use defstruct

  def get_categories do
    case File.ls("static/writings") do
      {:ok, categories} ->
        {:ok, Enum.filter(categories, fn str -> not String.contains?(str, ".") end)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_categories! do
    {:ok, categories} = get_categories()
    categories
  end
  
  # TODO: filter based on file metadata and keep in memory
  def get_category(category) do
    case File.ls( Path.join([ "static", "writings", category ]) ) do
      {:ok, file_names} ->
        {:ok, Enum.map(file_names, &Path.rootname/1)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_category!(category) do
    {:ok, category} = get_category(category)
    category
  end
    
  # TODO: Make a markdown meta section for use with JSON-LD
  def get_article(category, title) do
    md   = File.read( Path.join([ "static", "writings", category, title <> ".md"   ]) )
    html = File.read( Path.join([ "static", "writings", category, title <> ".html" ]) )
    case {md, html} do
      {{:ok, body}, _} -> {:ok, Earmark.as_html!(body, %Earmark.Options{code_class_prefix: "lang-"})}
      {_, {:ok, body}} -> {:ok, body}
      {{:error, :enoent}, {:error, :enoent}} -> {:error, :enoent}
      {{:error, reason}, _} -> {:error, reason}
      {_, {:error, reason}} -> {:error, reason}
    end
  end

  def get_article!(category, title) do
    {:ok, article} = get_article(category, title)
    article
  end

end
