<Query Kind="Expression">
  <Output>DataGrids</Output>
  <NuGetReference Prerelease="true">TIKSN-Framework</NuGetReference>
  <Namespace>System.Globalization</Namespace>
</Query>

CultureInfo.GetCultures(CultureTypes.AllCultures)
	.GroupBy(k => k.ThreeLetterWindowsLanguageName)
	.Select(x => Tuple.Create(x.Key, x.Count(), x))
	.GroupBy(x => x.Item2)