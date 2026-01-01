defmodule Portfolio.ContentProcessor do
  @moduledoc """
  Processes blog content from various formats to HTML.
  Designed to be easily extensible for new formats.
  """
  require Logger

  @supported_formats ["markdown"]

  def supported_formats, do: @supported_formats

  def process(content, "markdown") do
    {content_without_math, math_expressions} = extract_math_expressions(content)

    case Earmark.as_html(content_without_math, earmark_options()) do
      {:ok, html, _messages} ->
        html
        |> restore_math_expressions(math_expressions)
        |> fix_code_block_classes()

      {:error, _html, messages} ->
        Logger.warning("Markdown processing errors: #{inspect(messages)}")
        "<pre>#{Phoenix.HTML.html_escape(content)}</pre>"
    end
  end

  def process(content, format) do
    Logger.warning("Unsupported format: #{format}. Supported: #{inspect(@supported_formats)}")
    "<pre>#{Phoenix.HTML.html_escape(content)}</pre>"
  end

  defp earmark_options do
    %Earmark.Options{
      breaks: true,
      gfm: true,
      code_class_prefix: "",
      smartypants: true
    }
  end

  defp extract_math_expressions(content) do
    display_matches = Regex.scan(~r/\$\$([^$]+)\$\$/, content)
    inline_matches = Regex.scan(~r/\$([^$]+)\$/, content)

    {content, math_expressions, _} =
      Enum.reduce(display_matches, {content, [], 0}, fn [full_match, expr],
                                                        {acc_content, acc_expressions, idx} ->
        marker = "MATH_DISPLAY_#{idx}_MARKER"
        new_expressions = acc_expressions ++ [{:display, expr}]
        new_content = String.replace(acc_content, full_match, marker, global: false)
        {new_content, new_expressions, idx + 1}
      end)

    {content, math_expressions, _} =
      Enum.reduce(inline_matches, {content, math_expressions, length(display_matches)}, fn [
                                                                                             full_match,
                                                                                             expr
                                                                                           ],
                                                                                           {acc_content,
                                                                                            acc_expressions,
                                                                                            idx} ->
        marker = "MATH_INLINE_#{idx}_MARKER"
        new_expressions = acc_expressions ++ [{:inline, expr}]
        new_content = String.replace(acc_content, full_match, marker, global: false)
        {new_content, new_expressions, idx + 1}
      end)

    {content, math_expressions}
  end

  defp restore_math_expressions(html, math_expressions) do
    Enum.reduce(Enum.with_index(math_expressions), html, fn {{type, expr}, idx}, acc ->
      marker =
        case type do
          :display -> "MATH_DISPLAY_#{idx}_MARKER"
          :inline -> "MATH_INLINE_#{idx}_MARKER"
        end

      replacement =
        case type do
          :display -> "<span class=\"math display\">\\[\n#{expr}\n\\]</span>"
          :inline -> "<span class=\"math inline\">\\(#{expr}\\)</span>"
        end

      String.replace(acc, marker, replacement)
    end)
  end

  defp fix_code_block_classes(html) do
    # Convert from Earmark's format to highlight.js format
    # Earmark produces: <pre><code class="elixir">
    # highlight.js expects: <pre><code class="language-elixir">
    Regex.replace(~r/<pre><code class="([^"]+)">/, html, fn _match, lang ->
      "<pre><code class=\"language-#{lang}\">"
    end)
  end
end
