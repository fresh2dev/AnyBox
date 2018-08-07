function Test-ValidInput {
	Param(
		$AllPrompts,
		[ref]$RefForm,
		$childWinParams,
		$ok_btn
	)
	[bool]$valid = $true
	foreach ($prmpt in $AllPrompts)
	{
		[string]$msg = $null

		if ($prmpt.ValidateNotEmpty -and -not $RefForm.Value.Result.($prmpt.Name)) {
				if ($prmpt.ValidateSet) {
					$msg = 'Please make a selection.'
				}
				elseif ($prmpt.InputType -eq [AnyBox.InputType]::Link) {
					$msg = 'Please click the link.'
				}
				elseif ($prmpt.Message) {
					$msg = "Please provide input for '{0}'" -f $prmpt.Message.TrimEnd(':').Trim()
				}
				else {
					$msg = 'Please provide input for required fields.'
				}
		}
		elseif ($prmpt.ValidateScript -and -not ($RefForm.Value.Result.($prmpt.Name) | ForEach-Object -Process $prmpt.ValidateScript)) {
			if ($prmpt.Message) {
				$msg = "Invalid input for '{0}'" -f $prmpt.Message.TrimEnd(':')
			}
			else {
				$msg = "Invalid input provided."
			}
		}

		if ($msg) {
			$null = Show-AnyBox @childWinParams -Message $msg -Buttons $ok_btn
			#$null = ($RefForm.Value.Result.($prmpt.Name)).Focus()
			$valid = $false
			break
		}
	}
	return($valid)
}