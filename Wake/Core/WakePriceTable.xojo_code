#tag Class
Protected Class WakePriceTable
	#tag Method, Flags = &h0
		Sub Constructor()
		  mPrices = WakeCore.NewCaseSensitiveDictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Estimate(byModel As Dictionary) As WakeCostEstimate
		  // The cost of token usage keyed by model name. Models without a price are listed in the
		  // result and left out of its amount.
		  Var result As New WakeCostEstimate
		  If byModel Is Nil Then Return result
		  
		  For Each key As Variant In byModel.Keys
		    Var model As String = key.StringValue
		    Var amount As WakeTokenUsage = WakeTokenUsage(byModel.Value(key).ObjectValue)
		    If amount Is Nil Or amount.IsEmpty Then Continue
		    
		    Var price As WakeModelPrice = PriceFor(model)
		    If price Is Nil Then
		      result.UnpricedTokens = result.UnpricedTokens + amount.Total
		      If result.UnpricedModels.IndexOf(model) < 0 Then result.UnpricedModels.Add(model)
		    Else
		      result.PricedTokens = result.PricedTokens + amount.Total
		      result.AmountUSD = result.AmountUSD + price.Cost(amount)
		    End If
		  Next
		  
		  result.UnpricedModels.Sort
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Load(f As FolderItem) As WakePriceTable
		  // Reads a price file written by Save. A missing file gives an empty table. A file that
		  // can't be read also gives an empty table, with LoadError set. Entries that don't make
		  // sense are skipped.
		  Var table As New WakePriceTable
		  If f Is Nil Or Not f.Exists Then Return table
		  
		  Try
		    Var input As TextInputStream = TextInputStream.Open(f)
		    input.Encoding = Encodings.UTF8
		    Var json As String = input.ReadAll
		    input.Close
		    
		    Var prices As Dictionary = WakeCore.JSONDictionary(WakeCore.AsDictionary(ParseJSON(json)), "prices")
		    If prices Is Nil Then
		      table.LoadError = f.Name + " has no ""prices"" object."
		      Return table
		    End If
		    
		    For Each key As Variant In prices.Keys
		      Var entry As Dictionary = WakeCore.AsDictionary(prices.Value(key))
		      If entry Is Nil Or key.StringValue = "" Then Continue
		      
		      Var price As New WakeModelPrice(key.StringValue)
		      price.InputPerMillion = Max(0.0, WakeCore.JSONDouble(entry, "input"))
		      price.OutputPerMillion = Max(0.0, WakeCore.JSONDouble(entry, "output"))
		      price.CacheWritePerMillion = Max(0.0, WakeCore.JSONDouble(entry, "cacheWrite"))
		      price.CacheWrite1hPerMillion = Max(0.0, WakeCore.JSONDouble(entry, "cacheWrite1h"))
		      price.CacheReadPerMillion = Max(0.0, WakeCore.JSONDouble(entry, "cacheRead"))
		      table.SetPrice(price)
		    Next
		  Catch err As IOException
		    table.LoadError = "Could not read " + f.Name + ": " + err.Message
		  Catch err As JSONException
		    table.LoadError = f.Name + " is not valid JSON: " + err.Message
		  Catch err As TypeMismatchException
		    table.LoadError = f.Name + " is not a price file."
		  End Try
		  
		  Return table
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Models() As String()
		  // Every model with a price, sorted by name.
		  Var result() As String
		  For Each key As Variant In mPrices.Keys
		    result.Add(key.StringValue)
		  Next
		  result.Sort
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ParsePrice(text As String, ByRef value As Double) As Boolean
		  // Reads a price typed by the user, such as "3", "3.5", "3,5" or "$0.30", whatever the
		  // locale. Returns False for anything else, negative and empty values included.
		  // String.ToDouble follows the locale, where "." can be a thousands separator and turn
		  // "3.00" into 300, so the text is checked here and converted with Val, which always
		  // reads "." as the decimal point.
		  Var cleaned As String = text.Trim.ReplaceAll("$", "").ReplaceAll(" ", "").ReplaceAll(",", ".")
		  If cleaned = "" Then Return False
		  
		  Var digits, points As Integer
		  For i As Integer = 0 To cleaned.Length - 1
		    Var character As String = cleaned.Middle(i, 1)
		    If character = "." Then
		      points = points + 1
		    ElseIf character >= "0" And character <= "9" Then
		      digits = digits + 1
		    Else
		      Return False
		    End If
		  Next
		  If digits = 0 Or points > 1 Then Return False
		  
		  value = Val(cleaned)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PriceFor(model As String) As WakeModelPrice
		  // The price set for model, or Nil. A dated model name such as
		  // claude-haiku-4-5-20251001 also uses the price of claude-haiku-4-5.
		  If mPrices.HasKey(model) Then Return WakeModelPrice(mPrices.Value(model).ObjectValue)
		  
		  Var parts() As String = model.Split("-")
		  If parts.Count > 1 Then
		    Var suffix As String = parts(parts.LastIndex)
		    Var isDate As Boolean = suffix.Length = 8
		    For i As Integer = 0 To suffix.Length - 1
		      Var character As String = suffix.Middle(i, 1)
		      If character < "0" Or character > "9" Then isDate = False
		    Next
		    If isDate Then
		      parts.RemoveAt(parts.LastIndex)
		      Var undated As String = String.FromArray(parts, "-")
		      If mPrices.HasKey(undated) Then Return WakeModelPrice(mPrices.Value(undated).ObjectValue)
		    End If
		  End If
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemovePrice(model As String)
		  If mPrices.HasKey(model) Then mPrices.Remove(model)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Save(f As FolderItem)
		  // Writes every price as JSON. Raises IOException when the file can't be written.
		  Var prices As New Dictionary
		  For Each model As String In Models
		    Var price As WakeModelPrice = WakeModelPrice(mPrices.Value(model).ObjectValue)
		    Var entry As New Dictionary
		    entry.Value("input") = price.InputPerMillion
		    entry.Value("output") = price.OutputPerMillion
		    entry.Value("cacheWrite") = price.CacheWritePerMillion
		    entry.Value("cacheWrite1h") = price.CacheWrite1hPerMillion
		    entry.Value("cacheRead") = price.CacheReadPerMillion
		    prices.Value(model) = entry
		  Next
		  
		  Var root As New Dictionary
		  root.Value("unit") = "US dollars per million tokens"
		  root.Value("prices") = prices
		  
		  Var folder As FolderItem = f.Parent
		  If folder <> Nil And Not folder.Exists Then folder.CreateFolder
		  
		  Var output As TextOutputStream = TextOutputStream.Create(f)
		  output.Encoding = Encodings.UTF8
		  output.Write(GenerateJSON(root, True))
		  output.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrice(price As WakeModelPrice)
		  If price Is Nil Or price.Model = "" Then Return
		  mPrices.Value(price.Model) = price
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		LoadError As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrices As Dictionary
	#tag EndProperty


End Class
#tag EndClass
