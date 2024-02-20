        $code = [Int32]1
        $returncode = 2147942401
        #$returncode = 2147942402
        $returncode = 4294967295
        #$returncode = 4294967040
        #$returncode = 4294967294
        $returncode = 4294967040          # -256 Works

        $realcodeexited = 0
        if ($returncode -ge 65536 -and $returncode -le 2147942402) {
            $transform = [bigint]::Pow(2,16)-1
            $realcodeexited = $returncode -band $transform
        }
        else {
            $transform = [bigint]::Pow(2,16)-1
            #$realcodeexited = $returncode -bxor $transform
            $realcodeexited = $returncode - 4294967296
            # 4294967295 => -1
            # 4294967040 => -65536
        }            
                                                              
        Write-AllPlaces "Action return code $returncode is really $realcodeexited"
