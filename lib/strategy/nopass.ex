defmodule Ueberauth.Strategy.Nopass do
  @moduledoc """
  Strategy for using mail-based authentication
  """

  use Ueberauth.Strategy, uid_field: :email,
    email_field: :email,
    name_field: :name,
    first_name_field: :first_name,
    last_name_field: :last_name,
    nickname_field: :nickname,
    phone_field: :phone,
    location_field: :location,
    description_field: :description,
    password_field: :password,
    password_confirmation_field: :password_confirmation,
    param_nesting: nil,
    scrub_params: true

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Auth

  def handle_request!(conn) do
    redirect!(conn, "/nopass/do")
  end

  def handle_auth!(conn) do
    conn
    |> check_auth
  end

  def info(conn) do
    struct(
      Info,
      email: param_for(conn, :email_field)
    )
  end

  defp check_auth(%Plug.Conn{params: %{"code" => code}} = conn) do
    case UeberauthNopass.Store.check(code) do
      :error -> set_errors!(conn, [error("code_not_valid", "Code is not valid")])
      _ -> put_private(conn, :email, UeberauthNopass.Store.get_email(code))
    end
  end

  defp check_auth(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end


  defp option(conn, name) do
    Keyword.get(options(conn), name, Keyword.get(default_options(), name))
  end

  defp param_for(conn, name) do
    param_for(conn, name, option(conn, :param_nesting))
  end

  defp param_for(conn, name, nil) do
    conn.params
    |> Map.get(to_string(option(conn, name)))
    |> scrub_param(option(conn, :scrub_params))
  end

  defp param_for(conn, name, nesting) do
    attrs = nesting
    |> List.wrap
    |> Enum.map(fn(item) -> to_string(item) end)

    case Kernel.get_in(conn.params, attrs) do
      nil -> nil
      nested ->
        nested
        |> Map.get(to_string(option(conn, name)))
        |> scrub_param(option(conn, :scrub_params))
    end
  end

  defp scrub_param(param, false), do: param
  defp scrub_param(param, _) do
    if scrub?(param), do: nil, else: param
  end

  defp scrub?(" " <> rest), do: scrub?(rest)
  defp scrub?(""), do: true
  defp scrub?(_), do: false
end
