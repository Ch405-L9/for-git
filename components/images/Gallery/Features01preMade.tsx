/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/features-01pre-made.png';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Features01preMade({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Features 01pre Made'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
