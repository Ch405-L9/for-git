/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/features-02pre-made.png';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Features02preMade({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Features 02pre Made'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
