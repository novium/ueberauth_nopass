defmodule UeberauthNopass.Controller.View.Authenticate do
  #use Phoenix.Controller
  #import Bamboo.Email

  #def new(conn, _params) do
  #  conn
  #  |> render(UeberauthNopass.Views.Do, "do.html")
  #end

  #defp create_new_auth(conn) do
  #  code = :crypto.strong_rand_bytes(10) |> Base.url_encode64 |> binary_part(0, 10)
#
 #   response = UeberauthNopass.Store.new(code, "elmoo32@gmail.com")#

  #  new_email(
  #    from: "auth@novium.pw",
  #    to: "elmoo32@gmail.com",
  #    subject: "Authentication request",
  #    text_body: "Hi! Either click this link http://localhost:4001/auth/nopass/callback/?" <> code <> " or enter " <> code
  #  ) |> UeberauthNopass.Mailer.deliver_now
  #end
end
