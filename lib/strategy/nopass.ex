defmodule Ueberauth.Strategy.Nopass do
  @moduledoc """
  Strategy for using mail-based authentication
  """

  use Ueberauth.Strategy, email: :email,
    host: :host,
    callback: :callback

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth

  def handle_request!(%{params: %{"email" => email}} = conn) do
    {:ok, id, sessionid} = create_new_auth(email, conn)

    conn
    |> Plug.Conn.put_session("session_id", sessionid)
    |> Plug.Conn.put_session("id", id)
    |> assign(:status, :ok_waiting)
  end

  def handle_request!(conn) do
    conn
    |> set_errors!([error("no_email_provided", "No email was provided")])
  end

  def handle_callback!(conn) do
    conn
    |> check_auth
  end

  def handle_cleanup!(conn) do
    conn
    |> Plug.Conn.delete_session("session_id")
    |> Plug.Conn.delete_session("id")
  end

  def info(conn) do
    struct(
      Info,
      email: UeberauthNopass.Store.get_email(conn.params["id"])
    )
  end

  def auth(conn) do
    struct(
      Auth,
      info: info(conn),
      uid: UeberauthNopass.Store.get_email(conn.params["id"])
    )
  end

  defp check_auth(%Plug.Conn{params: %{"id" => id, "code" => code}} = conn) do
    case UeberauthNopass.Store.check_code(id, code) do
      :not_found -> set_errors!(conn, [error("code_not_found", "Code has already been used or is invalid")])
      :authorized -> set_errors!(conn, [error("code_already_used", "Code has already been used")])
      :done -> set_errors!(conn, [error("code_already_used", "Code has already been used")])
      :waiting ->
        UeberauthNopass.Store.authenticate_code(id, code) # Set the code to used.
        conn
        |> assign(:status, :ok_authorized)
        |> Phoenix.Controller.put_flash(:info, "Ok!")
        |> Phoenix.Controller.redirect(to: "/")
    end
  end

  defp check_auth(%Plug.Conn{params: %{"id" => id, "check" => "1"}} = conn) do
    sessionid = Plug.Conn.get_session(conn, "session_id")

    case UeberauthNopass.Store.check_session(id, sessionid) do
      :not_found -> 
        conn
        |> set_errors!([error("session_error", "Session invalid or no request pending")])
        |> Phoenix.Controller.text("false")
      :waiting ->
        conn
        |> Phoenix.Controller.text("false")
      :authorized ->
        # Session authenticated!
        # UeberauthNopass.Store.complete(code) # Set the code to used.
        conn
        |> Phoenix.Controller.text("true")
    end
  end

  defp check_auth(%Plug.Conn{params: %{"id" => id, "authenticate" => "1"}} = conn) do
    sessionid = Plug.Conn.get_session(conn, "session_id")

    case UeberauthNopass.Store.authenticate_session(id, sessionid) do
      :error -> 
        conn
        |> set_errors!([error("session_error", "Session invalid or no request pending")])
      _ ->
        # Session authenticated!
        # UeberauthNopass.Store.complete(code) # Set the code to used.
        conn
    end
  end

  defp check_auth(conn) do
    set_errors!(conn, [error("authentication_error", "No code or session authentication/authorization provided.")])
  end

  defp create_new_auth(email, conn) do
    id = :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)
    code = :crypto.strong_rand_bytes(10) |> Base.url_encode64 |> binary_part(0, 10)
    session_id = :crypto.strong_rand_bytes(20) |> Base.url_encode64 |> binary_part(0, 20)

    UeberauthNopass.Store.new(id, code, session_id, email)

    Bamboo.Email.new_email(
      from: option(conn, :email),
      to: email,
      subject: "[" <> "Core" <> "] Authentication request",
      text_body: "Hi! Either click this link " <> option(conn, :host) <> option(conn, :callback) 
        <> "/?id=" <> id 
        <> "&code=" <> code <> " or enter " <> code
    ) |> UeberauthNopass.Mailer.deliver_now

    {:ok, id, session_id}
  end

  defp option(conn, name) do
    Keyword.get(options(conn), name, Keyword.get(default_options(), name))
  end
end
