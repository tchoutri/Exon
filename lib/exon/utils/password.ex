defmodule Exon.Utils.Password do

  @spec check(String.t) :: {:ok, :strong} | {:error, String.t}
  def check(password) do
    m_u = "Password must contain at least an uppercase character"
    m_s = "Password must be at least 7 characters long"
    m_d = "Password must contain at least a digit"

    
    complexity = longer_than_seven([uppercase: 0, seven: 0, digits: 0], password)
      |> contains_uppercase(password)
      |> contains_digits(password)

    result = complexity
      |> Keyword.values
      |> Enum.sum

      # **TBD** 
  end


  defp longer_than_seven(complexity, password) do
    new_comp = case String.length(password) do
      7 -> add_one(complexity, :seven)
      _ -> complexity
    end
      contains_uppercase(password, new_comp)
  end

  defp contains_uppercase(complexity, password) do
    new_comp = if String.match?(password, ~r/[A-Z]/u) do
      add_one(complexity, :uppercase)
    else
      complexity
    end
      contains_digits(password, new_comp)
  end

  defp contains_digits(complexity, password) do
    if String.match?(password, ~r/[0-9]/u) do
      add_one(complexity, :digits)
    else
      complexity
    end
  end

  @spec add_one(list, atom) :: list | no_return
  defp add_one(keywords_list, key) when is_list(keywords) and is_atom(key) do
    Keyword.update!(keywords_list, key, &(&1 +1))
  end

end
