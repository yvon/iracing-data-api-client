defmodule Iracing.Api do
  @callback authenticate(binary, binary) :: []
  @callback get(list, binary, list) :: %{}
  @callback get(binary) :: %{}
end
