/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/features-03pre-made.png';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Features03preMade({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Features 03pre Made'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
