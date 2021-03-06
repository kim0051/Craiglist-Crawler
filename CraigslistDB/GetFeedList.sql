﻿CREATE FUNCTION [dbo].[GetFeedList]
(
	@IPFilter varchar(15)
)
RETURNS @Result TABLE
(
	City varchar(255) NOT NULL,
	SiteSection char(3) NOT NULL,
	SubCity char(3),
	[Timestamp] datetime NOT NULL
)
AS
BEGIN
	INSERT @Result
	SELECT
		CLCity.Name,
		CLSiteSection.Name,
		CLSubCity.SubCity,
		coalesce(max(Listing.Timestamp), cast(0 as datetime))
	FROM CLSiteSection
	cross join CLCity
	left join CLSubCity
		on CLSubCity.ParentCity = CLCity.Name
	left join Listing
		on Listing.City = CLCity.Name
		and (Listing.SubCity = CLSubCity.SubCity or Listing.SubCity is null and CLSubCity.SubCity is null)
		and listing.SiteSection = CLSiteSection.Name
	where
		CLSiteSection.Enabled = 1
		and CLCity.Enabled = 1
		AND 
		(
			CLCity.IP = @IPFilter
			or @IPFilter is null
		)
	group by CLCity.Name, CLSiteSection.Name, CLSubCity.SubCity, CLCity.IP
	RETURN 
END