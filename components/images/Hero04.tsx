/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/hero-04.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Hero04({ alt, ...rest }: Props) {
  return <img src={String(src)} alt={alt ?? 'Hero 04'} loading="lazy" decoding="async" {...rest} />;
}
