defmodule PhoenixInDockerWeb.PageController do
  use PhoenixInDockerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
