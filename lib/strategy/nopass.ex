defmodule Ueberauth.Strategy.Nopass do
  @moduledoc """
  Strategy for using mail-based authentication
  """

  use Ueberauth.Strategy, email: :email,
    host: :host,
    callback: :callback


  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Auth

  def handle_request!(%{params: %{"email" => email}} = conn) do
    create_new_auth(email, conn)
    redirect!(conn, "/nopass/do")
  end

  def handle_request!(conn) do
    halt(conn)
  end

  def handle_callback!(conn) do
    conn
    |> check_auth
  end

  def info(conn) do
    struct(
      Info,
      email: UeberauthNopass.Store.get_email(conn.params["code"])
    )
  end

  def auth(conn) do
    struct(
      Auth,
      info: info(conn),
      uid: UeberauthNopass.Store.get_email(conn.params["code"])
    )
  end

  defp check_auth(%Plug.Conn{params: %{"code" => code}} = conn) do
    case UeberauthNopass.Store.check(code) do
      :error -> set_errors!(conn, [error("code_not_valid", "Code is not valid")])
      :authorized -> set_errors!(conn, [error("code_already_used", "Code has already been used")])
      :not_authorized ->
        # UeberauthNopass.Store.complete(code)
        conn
    end
  end

  defp create_new_auth(email, conn) do
    code = :crypto.strong_rand_bytes(10) |> Base.url_encode64 |> binary_part(0, 10)

    UeberauthNopass.Store.new(code, "elmoo32@gmail.com")

    Bamboo.Email.new_email(
      from: option(conn, :email),
      to: email,
      subject: "Authentication request",
      text_body: "Hi! Either click this link " <> option(conn, :host) <> option(conn, :callback) <> "/?code=" <> code <> " or enter " <> code
    ) |> UeberauthNopass.Mailer.deliver_now
  end

  defp option(conn, name) do
    Keyword.get(options(conn), name, Keyword.get(default_options(), name))
  end
end
