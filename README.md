# CollectionViewTesting

This projects demonstrates a potential bug in `UICollectionView`, or – more likely – my misunderstanding of how updates are applied.

I _looks_ like applying _n_ deletes will cause the last _n_ cells in the section to never be reloaded.

See [CollectionViewController.swift](CollectionViewTesting/CollectionViewController.swift).
