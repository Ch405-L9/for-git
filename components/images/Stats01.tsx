/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/stats-01.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Stats01({ alt, ...rest }: Props) {
  return (
    <img src={String(src)} alt={alt ?? 'Stats 01'} loading="lazy" decoding="async" {...rest} />
  );
}
