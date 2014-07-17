# Create a news digest
n = NewsDigest.create!

# Article 1
title1 = 'A harbinger of good times ahead'
summary1 = 'As the Finance Minister has clarified that Goods and Services Tax is not an issue of debate, we can look forward to its implementation in the not-so-distant-future. It is, therefore, good to note that the Finance Minister has presented a responsible trajectory on this front. The investors and the business community can surely look at this budget as a harbinger of acche din.'
topic1 = 'Budget'
url1 = 'http://www.thehindu.com/business/budget/a-harbinger-of-good-times-ahead/article6198859.ece'
img1 = 'http://www.thehindu.com/multimedia/dynamic/01997/12TH_JAITLEY_1997443f.jpg'

# Article 2
title2 = 'Hero Romero!' 
summary2 = 'It had been a wretched semifinal until those moments when the players lined up in the centre circle for that last test of nerve and Holland should not just reflect on the inability of Ron Vlaar and Wesley Sneijder to beat the Argentina goalkeeper, Sergio Romero, but also the fact its entire team did not manage a single shot on target during the 120 minutes that preceded the shootout. Romero blocked the first attempt from Vlaar and produced an even better save, diving full-length to his right, to turn away Wesley Sneijder’s powerful effort. Romero’s goalkeeping had made the difference and, in the process, confirmed a re-run of the 1986 and 1990 finals.' 
topic2 = 'FIFA 2014'
url2 = 'http://www.thehindu.com/sport/football/fifa-2014/hero-romero/article6198144.ece'
img2 = 'http://www.thehindu.com/multimedia/dynamic/01993/TH11_ARGENTINA_2_1993999f.jpg'

n.articles.create!(title: title1, summary: summary1, topic: topic1, url: url1, img: img1)
n.articles.create!(title: title2, summary: summary2, topic: topic2, url: url2, img: img2)
n.articles.create!(title: title1, summary: summary1, topic: topic1, url: url1, img: img1)
n.articles.create!(title: title2, summary: summary2, topic: topic2, url: url2, img: img2)
n.articles.create!(title: title1, summary: summary1, topic: topic1, url: url1, img: img1)
n.articles.create!(title: title2, summary: summary2, topic: topic2, url: url2, img: img2)
n.articles.create!(title: title1, summary: summary1, topic: topic1, url: url1, img: img1)
n.articles.create!(title: title2, summary: summary2, topic: topic2, url: url2, img: img2)
n.articles.create!(title: title1, summary: summary1, topic: topic1, url: url1, img: img1)
n.articles.create!(title: title2, summary: summary2, topic: topic2, url: url2, img: img2)