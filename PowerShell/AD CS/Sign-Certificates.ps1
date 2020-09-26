# NOTE: must create AND submit the template AND manually enroll on the domain admin account
# 1474E3E9D227E5968DEFD35294379118E48B70D8 is the most recent one
# TODO Filter certificates?
Set-AuthenticodeSignature C:\certexp.ps1 -Certificate (Get-ChildItem Cert:\CurrentUser\My- -CodeSigningCert)[0]
    #* NOTE: May not work on every certificate type