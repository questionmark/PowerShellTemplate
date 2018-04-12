# We can add using statements here, to utilize unexposed types from other modules
# TODO: add example of usage without referencing QM

# As we know 00-init will probably be added to the top of the psm1 by Optimize-Module, we can add other dependencies for the module here.
Update-TypeData -TypeName HashTable -MemberType ScriptMethod -MemberName Where -Force -Value {
    param([ScriptBlock]$Filter, $Count=0)
    [hashtable][Linq.Enumerable]::ToDictionary(
        [Collections.Generic.IEnumerable[PSObject]]($this.GetEnumerator().Where($Filter, $Count)),
        [Func[PSObject, PSObject]] {$args[0].Key},
        [Func[PSObject, PSObject]] {$args[0].Value}
    )
}
# Thanks to @Jaykul for this example of adding .Where{} to the HashTable type