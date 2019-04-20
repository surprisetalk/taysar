defmodule Taysar.Sitemap do

  use Task,
    restart: :transient

  # BUG: www?
  use Sitemap,
    host: "http://taysar.com",
    files_path: "static/sitemaps/",
    public_path: "sitemaps/",
    compress: false

  def start_link(_arg) do
    generate_sitemap()
    Task.start_link(&poll/0)
  end

  def poll() do
    receive do
    after
      86_400_000 ->
        generate_sitemap()
        ping()
        poll()
    end
  end

  defp generate_sitemap() do
    create do
      add "/",
        priority: 1,
        changefreq: "weekly",
        lastmod: lastmod(".", "templates/index.eex")
      for category <- File.ls!("static/writings"),
        not String.starts_with?(category, ".") do
          add Path.join("/", category),
            priority: 0.3,
            changefreq: "weekly",
            lastmod: lastmod("static/writings", category)
          for article <- File.ls!( Path.join([ "static", "writings", category ]) ),
            not String.starts_with?(article, ".") do
              add Path.join(["/", category,  URI.encode(Path.rootname(article), &URI.char_unreserved?/1)]),
                priority: 0.5,
                lastmod: lastmod("static/writings", Path.join(category, article))
          end
      end
    end
  end

  # git -C static/writings ls-files -z category | xargs -0 -n1 -I{} -- git -C static/writings log -1 --format="%ai {}" {}
  defp lastmod(git_root, fpath) do
    case System.cmd("git", ["-C", git_root, "log", "-1", "--pretty=format:%aI", "#{fpath}"]) do
      {lastmod,0} -> lastmod
      _ -> nil
    end
  end

end
