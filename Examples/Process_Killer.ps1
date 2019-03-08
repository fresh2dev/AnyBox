Import-Module "..\AnyBox.psd1"

$anybox = New-Object AnyBox.AnyBox

$anybox.Title = 'Process Killer'
$anybox.ResizeMode = 'CanResizeWithGrip'
$anybox.MaxHeight = 800
$anybox.MaxWidth = 600
$anybox.Topmost = $true
$anybox.AccentColor = 'Black'

$anybox.GridData = @(Get-WmiObject -Class Win32_Process -ea Stop | select ProcessId, ProcessName, CommandLine)
$anybox.NoGridSearch = $true
$anybox.SelectionMode = [AnyBox.DataGridSelectionMode]::MultiRow

# Define the computer name prompt; the field must not be empty and the computer must be online.
$anybox.Prompts = @(New-AnyBoxPrompt -Group 0 -Name 'pcName' -Message 'Computer Name:' -MessagePosition 'Left' -DefaultValue 'Localhost' `
                  -ValidateNotEmpty -ValidateScript { Test-Connection $_ -Count 1 -Quiet -ea 0})

# Define the process filter prompt
$anybox.Prompts += @(New-AnyBoxPrompt -Group 0 -Name 'pFilter' -Message '    Process Name:' -MessagePosition 'Left' -DefaultValue '*' `
                    -ValidateNotEmpty)

# Define the 'Refresh' button.
$anybox.Buttons = New-AnyBoxButton -Text 'Refresh' -IsDefault -OnClick {
  # Run 'Test-ValidateInput' to enforce
  # the validation parameters set on the 'pcName' prompt.
  $input_test = Test-ValidInput -Prompts $Prompts -Inputs $form.Result
  if (-not $input_test.Is_Valid) {
    $null = Show-AnyBox @childWinParams -Message $input_test.Message -Buttons $(New-AnyBoxButton -Text 'OK' -IsDefault)
    $form['data_grid'].ItemsSource = $null
  }
  else {
    [string]$msg = $null
    try {
      # Get all running process matching the filter.
      # '$_.pcName' will access the text in the 'pcName' prompt.
      # '$_.pFilter' will access the text in the 'pFilter' prompt.
      $new_data = @(Get-WmiObject -cn $_.pcName -Class 'Win32_Process' `
                                  -Filter "Name LIKE '$($_.pFilter.Replace('*', '%'))'" -ea Stop |
                    select ProcessId, ProcessName, CommandLine)

      if ($new_data.Length -eq 0) {
        $form['data_grid'].ItemsSource = $null
        $msg = 'No processes match the provided filter.'
      }
      else {
        # Update the grid with matching processes.
        $form['data_grid'].ItemsSource = $new_data
      }
    }
    catch {
      $msg = $_.Exception.Message
    }

    # If an error occurs, show another AnyBox.
    # Show a child window with @childWinParams.
    if ($msg) { Show-AnyBox @childWinParams -Message $msg -Buttons 'OK' }
  }
}

$anybox.Buttons += New-AnyBoxButton -Template 'SaveGrid'

$anybox.Buttons += New-AnyBoxButton -Text 'Kill' -OnClick {
  # Run 'Test-ValidateInput' to enforce
  # the validation parameters set on the 'pcName' prompt.
  $input_test = Test-ValidInput -Prompts $Prompts -Inputs $form.Result
  if (-not $input_test.Is_Valid) {
    $null = Show-AnyBox @childWinParams -Message $input_test.Message -Buttons $(New-AnyBoxButton -Text 'OK' -IsDefault)
    $form['data_grid'].ItemsSource = $null
  }
  else {
    # Access selected grid rows with 'grid_select'.
    [array]$toKill = @($_.grid_select | select ProcessId, ProcessName)

    if ($toKill.Length -eq 0) {
      $null = Show-AnyBox @childWinParams -Message 'Select processes to kill.' -Buttons 'OK'
    }
    else {
      # Confirm before killing the selected processes.
      $answer = Show-AnyBox @childWinParams -Message 'Are you sure you want to kill the following processes?' `
                  -GridData $toKill -Buttons 'Cancel', 'Confirm'

      if ($answer['Confirm'])
      {
        [string]$pcName = $_.pcName

        $killed = @($toKill | foreach {
          [int]$code = 0
          [string]$msg = $null

          try {
            $code = ([wmi]"\\$pcName\root\cimv2:Win32_Process.Handle='$($_.ProcessId)'").Terminate().ReturnValue
            if ($code -eq 0) {
              $msg = 'Successfully closed.'
            }
          }
          catch {
            $code = -1
            $msg = $_.Exception.Message
          }

          $_ | select ProcessId, ProcessName, @{Name='Code';Expression={$code}}, @{Name='Message';Expression={$msg}}
        })

        [string]$msg = $null
        try {
          $new_data = @(Get-WmiObject -cn $_.pcName -Class 'Win32_Process' `
                                      -Filter "Name LIKE '$($_.pFilter.Replace('*', '%'))'" -ea Stop |
                        select ProcessId, ProcessName, CommandLine)

          if ($new_data.Length -eq 0) {
            $form['data_grid'].ItemsSource = $null
          }
          else {
            $form['data_grid'].ItemsSource = $new_data
          }
        }
        catch {
          $msg = $_.Exception.Message
        }

        # Output the results in child AnyBox with a DataGrid.
        $null = Show-AnyBox @childWinParams -GridData $killed -Buttons 'OK'

        # If an error occurred, show it in a child AnyBocx.
        if ($msg) { $null = Show-AnyBox @childWinParams -Message $msg -Buttons 'OK' }
      }
    }
  }
}

$anybox | Show-AnyBox | Out-Null
