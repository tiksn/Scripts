<Query Kind="Expression">
  <Output>DataGrids</Output>
  <NuGetReference Prerelease="true">TIKSN-Framework</NuGetReference>
  <Namespace>System.Globalization</Namespace>
</Query>

CultureInfo.GetCultures(CultureTypes.AllCultures)
	.Where(x => !x.IsNeutralCulture && !x.Equals(CultureInfo.InvariantCulture))
	.Select(x => new RegionInfo(x.Name))
	.GroupBy(k => k.ThreeLetterWindowsRegionName)
	.Select(x => Tuple.Create(x.Key, x.Count(), x))
	.GroupBy(x => x.Item2)