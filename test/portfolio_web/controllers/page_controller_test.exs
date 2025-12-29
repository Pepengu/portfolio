defmodule PortfolioWeb.PageControllerTest do
  use PortfolioWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to my portfolio"
  end
end
